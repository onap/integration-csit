class DMaaPQueue(object):

    def __init__(self, event_queue, wait_timeout_sec=25):
        self.event_queue = event_queue
        self.wait_timeout_sec = wait_timeout_sec

    def set_deque_event_timeout(self, wait_timeout_sec):
        self.wait_timeout_sec = wait_timeout_sec

    def clean_up_event(self):
        if self.queue_is_valid():
            with self.event_queue.mutex:
                try:
                    self.event_queue.queue.clear()
                except:
                    pass

    def enque_event(self, event):
        event_placed_on_queue = False
        if self.queue_is_valid():
            event_placed_on_queue = self._enque_event(event, event_placed_on_queue)
        return event_placed_on_queue

    def _enque_event(self, event, event_placed_on_queue):
        try:
            self.event_queue.put(event)
            event_placed_on_queue = True
        except Exception as e:
            print (str(e))
        return event_placed_on_queue

    def deque_event(self, wait_sec=None):
        if wait_sec is None:
            wait_sec = self.wait_timeout_sec
        event_from_queue = None
        if self.queue_is_valid():
            event_from_queue = self._deque_event(event_from_queue, wait_sec)
        return event_from_queue

    def _deque_event(self, event_from_queue, wait_sec):
        try:
            event_from_queue = self.event_queue.get(True, wait_sec)
        except Exception as e:
            print("DMaaP Event dequeue timeout")
        return event_from_queue

    def queue_is_valid(self):
        return self.event_queue is not None
