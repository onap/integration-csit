# environment variable must be set:
# export WORKSPACE=/home/bartosz/repos/onap/integration/csit
from Queue import Queue

import pytest
from ..dmaap.DMaaPQueue import DMaaPSQueue

wait_sec_for_dequeing_event = 0.1
test_event = "\"topic\":{\"test\":123}"

dmaap_simulator = None


@pytest.fixture(autouse=True)
def initiate_dmaap_simulator():
    global dmaap_simulator
    dmaap_simulator = DMaaPSQueue(Queue())
    dmaap_simulator.set_deque_event_timeout(wait_sec_for_dequeing_event)


def test_when_queue_is_empty_then_deque_returns_none():
    event = dmaap_simulator.deque_event()
    assert event is None


def test_when_enque_event_then_dequeue_return_same_event():
    dmaap_simulator.enque_event(test_event)
    event = dmaap_simulator.deque_event()
    assert event == test_event


def test_when_enque_and_dequeue_event_then_deque_return_none():
    dmaap_simulator.enque_event(test_event)
    dmaap_simulator.deque_event()
    event = dmaap_simulator.deque_event()
    assert event is None


def test_when_enque_few_events_and_clean_up_then_dequeu_return_none():
    dmaap_simulator.enque_event(test_event)
    dmaap_simulator.enque_event(test_event)
    dmaap_simulator.enque_event(test_event)
    dmaap_simulator.clean_up_event()
    event = dmaap_simulator.deque_event()
    assert event is None
