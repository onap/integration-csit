import sys
import pytest
from mock import MagicMock

sys.modules['robot'] = MagicMock()
sys.modules['robot.api'] = MagicMock()
sys.modules['robot.api.logger'] = MagicMock()
from robot_library.DmaapLibrary import DmaapLibrary

wait_sec_for_dequeing_event = 0.1
test_event = "{\"test\":\"123\"}"
test_topic = "topic"
test_message = "\"" + test_topic + "\":" + test_event


class TestDMaaPSimulator:

    @pytest.fixture(autouse=True, scope="class")
    def initiate_dmaap_simulator(self):
        DmaapLibrary.setup_dmaap_server()
        DmaapLibrary.dmaap_queue.set_deque_event_timeout(wait_sec_for_dequeing_event)
        yield
        assert DmaapLibrary.shutdown_dmaap() == "true"

    @pytest.fixture(autouse=True, scope="function")
    def clear_dmaap_simulator(self):
        yield
        DmaapLibrary.cleanup_ves_events()

    def test_start_stop_dmaap_server(self):
        # when / then
        assert DmaapLibrary.dmaap_queue is not None
        assert DmaapLibrary.dmaap_server is not None
        assert DmaapLibrary.server_thread is not None

    def test_dmaap_server_returns_true_when_event_is_present_on_queue(self):
        # when
        DmaapLibrary.dmaap_queue.enque_event(test_message)

        # then
        assert DmaapLibrary.dmaap_message_receive(test_event) == 'true'

    def test_dmaap_server_returns_true_when_event_is_present_on_given_topic_on_queue(self):
        # when
        DmaapLibrary.dmaap_queue.enque_event(test_message)

        # then
        assert DmaapLibrary.dmaap_message_receive_on_topic(test_event, test_topic) == 'true'

    def test_dmaap_server_returns_timeout_when_event_is_not_present_on_queue(self):
        # when / then
        assert DmaapLibrary.dmaap_message_receive(test_event) == 'false'

    def test_dmaap_server_returns_false_when_queue_was_cleared(self):
        # when
        DmaapLibrary.dmaap_queue.enque_event(test_message)
        DmaapLibrary.dmaap_queue.enque_event(test_message)
        DmaapLibrary.dmaap_queue.enque_event(test_message)
        DmaapLibrary.cleanup_ves_events()

        # then
        assert DmaapLibrary.dmaap_message_receive_on_topic(test_event, test_topic) == 'false'
