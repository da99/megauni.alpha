
def read_if_file(f)
  file_path = File.expand_path(f)
  File.file?(file_path) ? 
    File.read(file_path) :
    nil
end
