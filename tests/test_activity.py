import json
from pathlib import Path
import subprocess
import tempfile
import unittest


ROOT = Path(__file__).resolve().parents[1]
BINARY = ROOT / "dist/Habibi-Pet-Bot.app/Contents/MacOS/HabibiPetBot"


class ActivityBridgeTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.state = Path(self.temp.name) / "activity.json"

    def emit(self, event):
        subprocess.run(
            [str(BINARY), "--pet-hook", str(self.state)],
            input=json.dumps(event).encode(), check=True, timeout=5,
        )
        return json.loads(self.state.read_text())

    def test_task_survives_tool_events_without_storing_arguments(self):
        self.emit({"hook_event_name": "UserPromptSubmit", "prompt": "Build a pet\nwith a gallery"})
        result = self.emit({"hook_event_name": "PreToolUse", "tool_name": "Read",
                            "tool_input": {"secret": "do-not-retain-this"}})
        self.assertEqual(result["task"], "Build a pet with a gallery")
        self.assertIn("Read", result["title"])
        self.assertNotIn("do-not-retain-this", self.state.read_text())

    def test_lifecycle_and_approval_states(self):
        for event, phrase in [("SessionStart", "Ready"), ("PermissionRequest", "Approval"),
                              ("PostToolUseFailure", "failed"), ("Stop", "All done"),
                              ("SessionEnd", "ended")]:
            with self.subTest(event=event):
                self.assertIn(phrase, self.emit({"hook_event_name": event})["title"])

    def test_task_title_is_bounded(self):
        result = self.emit({"hook_event_name": "UserPromptSubmit", "prompt": "🐱" * 300})
        self.assertEqual(len(result["task"]), 100)

    def test_malformed_input_does_not_overwrite_state(self):
        before = self.emit({"hook_event_name": "Stop"})
        subprocess.run([str(BINARY), "--pet-hook", str(self.state)], input=b"bad json", check=True, timeout=5)
        self.assertEqual(json.loads(self.state.read_text()), before)

    def test_unknown_event_is_ignored(self):
        subprocess.run([str(BINARY), "--pet-hook", str(self.state)],
                       input=b'{"hook_event_name":"unknown"}', check=True, timeout=5)
        self.assertFalse(self.state.exists())


if __name__ == "__main__":
    unittest.main()
