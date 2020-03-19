
class EnvsReader:

  def read_list_env_from_file(self, path):
    f = open(path, "r")
    r_list = []
    for line in f:
      line = line.strip()
      if line[0] != "#":
        r_list.append(line)
    return r_list
