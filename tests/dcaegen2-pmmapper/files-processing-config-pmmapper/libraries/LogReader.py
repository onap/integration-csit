import re

class LogReader:

  def filter_unique(self, merged_logs_output, testname):
    logs = merged_logs_output.splitlines()
    del_logs = list(filter(lambda line: "|DEL|" in line, logs))
    nrs_set = set()
    ret_logs = set()
    for log in del_logs:
      filename = re.findall(testname + "\d", log)
      if len(filename) > 0 and filename[0] not in nrs_set:
        ret_logs.add(log)
        nrs_set.add(filename[0])
    return ret_logs

  def get_number_of_dropped_messages(self, logs_output):
    return len(list(filter(lambda line: "|429|" in line, logs_output)))

  def get_log_files_list(self, fileNames):
    files = fileNames.split()
    return files
