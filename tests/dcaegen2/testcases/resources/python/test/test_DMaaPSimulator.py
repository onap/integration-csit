from ..library.DmaapLibrary import DmaapLibrary

wait_sec_for_dequeing_event = 0.1
test_event = "\"topic\":{\"test\":123}"


def test_start_stop_dmaap_server():
    DmaapLibrary.setup_dmaap_server()
    assert DmaapLibrary.dmaap_queue is not None
    assert DmaapLibrary.dmaap_server is not None
    assert DmaapLibrary.server_thread is not None
    assert DmaapLibrary.shutdown_dmaap() == "true"


def test_dmaap_server_returns_true_when_event_is_present_on_queue():
    DmaapLibrary.setup_dmaap_server()
    DmaapLibrary.dmaap_queue.set_deque_event_timeout(wait_sec_for_dequeing_event)
    DmaapLibrary.dmaap_queue.enque_event(test_event)
    assert DmaapLibrary.dmaap_message_receive(test_event) == 'true'
    DmaapLibrary.shutdown_dmaap()


def test_dmaap_server_returns_timeout_when_event_is_not_present_on_queue():
    DmaapLibrary.setup_dmaap_server()
    DmaapLibrary.dmaap_queue.set_deque_event_timeout(wait_sec_for_dequeing_event)
    assert DmaapLibrary.dmaap_message_receive(test_event) == 'false'
    DmaapLibrary.shutdown_dmaap()
