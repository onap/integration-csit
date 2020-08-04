from Queue import Queue
import pytest
from robot_library.dmaap_simulator.DMaaPQueue import DMaaPQueue

wait_sec_for_dequeing_event = 0.1
test_event = "\"topic\":{\"test\":123}"


class TestDMaaPQueue:

    dmaap_simulator = None

    @pytest.fixture(autouse=True, scope="function")
    def initiate_dmaap_simulator(self):
        TestDMaaPQueue.dmaap_simulator = DMaaPQueue(Queue())
        TestDMaaPQueue.dmaap_simulator.set_deque_event_timeout(wait_sec_for_dequeing_event)
        yield

    def test_when_queue_is_empty_then_deque_returns_none(self):
        # when
        event = TestDMaaPQueue.dmaap_simulator.deque_event()

        # then
        assert event is None

    def test_when_enque_event_then_dequeue_return_same_event(self):
        # when
        TestDMaaPQueue.dmaap_simulator.enque_event(test_event)
        event = TestDMaaPQueue.dmaap_simulator.deque_event()

        # then
        assert event == test_event

    def test_when_enque_and_dequeue_event_then_deque_return_none(self):
        # when
        TestDMaaPQueue.dmaap_simulator.enque_event(test_event)
        TestDMaaPQueue.dmaap_simulator.deque_event()
        event = TestDMaaPQueue.dmaap_simulator.deque_event()

        # then
        assert event is None

    def test_when_enque_few_events_and_clean_up_then_dequeu_return_none(self):
        # when
        TestDMaaPQueue.dmaap_simulator.enque_event(test_event)
        TestDMaaPQueue.dmaap_simulator.enque_event(test_event)
        TestDMaaPQueue.dmaap_simulator.enque_event(test_event)
        TestDMaaPQueue.dmaap_simulator.clean_up_event()
        event = TestDMaaPQueue.dmaap_simulator.deque_event()

        # then
        assert event is None
