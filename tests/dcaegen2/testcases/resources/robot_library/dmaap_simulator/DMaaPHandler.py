'''
Created on Aug 15, 2017

@author: sw6830
'''
import os
import posixpath
import BaseHTTPServer
import urllib
import urlparse
import cgi
import sys
import shutil
import mimetypes
from robot_library import DcaeVariables

try:
    from cStringIO import StringIO
except ImportError:
    from StringIO import StringIO


class DMaaPHandler(BaseHTTPServer.BaseHTTPRequestHandler):

    def __init__(self, dmaap_simulator, *args):
        self.dmaap_simulator = dmaap_simulator
        BaseHTTPServer.BaseHTTPRequestHandler.__init__(self, *args)

    def do_PUT(self):
        self.send_response(405)

    def do_POST(self):
        if 'POST' not in self.requestline:
            resp_code = 405
        else:
            resp_code = self.parse_the_posted_data()

        if not DcaeVariables.IsRobotRun:
            print ("Response Message:")

        if resp_code == 0:
            self.send_successful_response()
        else:
            self.send_response(resp_code)

    def do_GET(self):
        f = self.send_head()
        if f:
            try:
                self.copyfile(f, self.wfile)
            finally:
                f.close()

    def do_HEAD(self):
        f = self.send_head()
        if f:
            f.close()

    def parse_the_posted_data(self):
        resp_code = 0
        topic = self.extract_topic_from_path()
        content_len = self.get_content_length()
        post_body = self.rfile.read(content_len)
        indx = post_body.index("{")
        if indx != 0:
            post_body = post_body[indx:]
        event = "\"" + topic + "\":" + post_body
        if not self.dmaap_simulator.enque_event(event):
            print "enque event fails"
            resp_code = 500
        return resp_code

    def extract_topic_from_path(self):
        return self.path["/events/".__len__():]

    def get_content_length(self):
        return int(self.headers.getheader('content-length', 0))

    def send_successful_response(self):
        if 'clientThrottlingState' in self.requestline:
            self.send_response(204)
        else:
            self.send_response(200)
            self.send_header('Content-Type', 'application/json')
            self.end_headers()
            self.wfile.write("{'count': 1, 'serverTimeMs': 3}")
            self.wfile.close()

    def send_head(self):
        """
        Common code for GET and HEAD commands.

        This sends the response code and MIME headers.

        Return value is either a file object (which has to be copied
        to the output file by the caller unless the command was HEAD,
        and must be closed by the caller under all circumstances), or
        None, in which case the caller has nothing further to do.
        """
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            output_file = self.handle_path_as_directory(path)
        else:
            output_file = self.handle_path_as_file(path)
        return output_file

    def handle_path_as_directory(self, path):
        parts = urlparse.urlsplit(self.path)
        if not parts.path.endswith('/'):
            self.redirect_browser_with_code_301(parts)
            return None
        for index in "index.html", "index.htm":
            index = os.path.join(path, index)
            if os.path.exists(index):
                break
        else:
            return self.list_directory(path)

    def redirect_browser_with_code_301(self, parts):
        self.send_response(301)
        new_parts = (parts[0], parts[1], parts[2] + '/',
                     parts[3], parts[4])
        new_url = urlparse.urlunsplit(new_parts)
        self.send_header("Location", new_url)
        self.end_headers()

    def handle_path_as_file(self, path):
        file_type = self.guess_type(path)
        try:
            # Always read in binary mode. Opening files in text mode may cause
            # newline translations, making the actual size of the content
            # transmitted *less* than the content-length!
            local_file = open(path, 'rb')
        except IOError:
            self.send_error(404, "File not found")
            return None
        try:
            self.send_response(200)
            self.send_header("Content-type", file_type)
            file_stream = os.fstat(local_file.fileno())
            self.send_header("Content-Length", str(file_stream[6]))
            self.send_header("Last-Modified", self.date_time_string(file_stream.st_mtime))
            self.end_headers()
            return local_file
        except:
            local_file.close()
            raise

    def list_directory(self, path):
        """
        Helper to produce a directory listing (absent index.html).

        Return value is either a file object, or None (indicating an
        error).  In either case, the headers are sent, making the
        interface the same as for send_head().
        """
        try:
            list_dir = os.listdir(path)
        except os.error:
            self.send_error(404, "No permission to list directory")
            return None
        list_dir.sort(key=lambda a: a.lower())
        response_content = StringIO()
        display_path = cgi.escape(urllib.unquote(self.path))
        self.write_directory_listing_header(display_path, response_content)
        for name in list_dir:
            self.write_directory_content(response_content, name, path)
        response_content.write("</ul>\n<hr>\n</body>\n</html>\n")
        length = response_content.tell()
        response_content.seek(0)
        self.send_response(200)
        encoding = sys.getfilesystemencoding()
        self.send_header("Content-type", "text/html; charset=%s" % encoding)
        self.send_header("Content-Length", str(length))
        self.end_headers()
        return response_content

    def write_directory_content(self, f, name, path):
        fullname = os.path.join(path, name)
        displayname = linkname = name
        # Append / for directories or @ for symbolic links
        if os.path.isdir(fullname):
            displayname = name + "/"
            linkname = name + "/"
        if os.path.islink(fullname):
            displayname = name + "@"
            linkname = name
        f.write('<li><a href="%s">%s</a>\n'
                % (urllib.quote(linkname), cgi.escape(displayname)))

    def write_directory_listing_header(self, displaypath, f):
        f.write('<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 3.2 Final//EN">')
        f.write("<html>\n<title>Directory listing for %s</title>\n" % displaypath)
        f.write("<body>\n<h2>Directory listing for %s</h2>\n" % displaypath)
        f.write("<hr>\n<ul>\n")

    @staticmethod
    def translate_path(path):
        """
        Translate a /-separated PATH to the local filename syntax.

        Components that mean special things to the local file system
        (e.g. drive or directory names) are ignored.  (XXX They should
        probably be diagnosed.)
        """
        path = DMaaPHandler.remove_query_parameter(path)
        contains_trailing_slash = path.rstrip().endswith('/')
        path = posixpath.normpath(urllib.unquote(path))
        words = path.split('/')
        words = filter(None, words)
        path = os.getcwd()
        for word in words:
            if os.path.dirname(word) or word in (os.curdir, os.pardir):
                # Ignore components that are not a simple file/directory name
                continue
            path = os.path.join(path, word)
        if contains_trailing_slash:
            path += '/'
        return path


    @staticmethod
    def remove_query_parameter(path):
        path = path.split('?', 1)[0]
        path = path.split('#', 1)[0]
        return path

    @staticmethod
    def copyfile(source, outputfile):
        """Copy all data between two file objects.

        The SOURCE argument is a file object open for reading
        (or anything with a read() method) and the DESTINATION
        argument is a file object open for writing (or
        anything with a write() method).

        The only reason for overriding this would be to change
        the block size or perhaps to replace newlines by CRLF
        -- note however that this the default server uses this
        to copy binary data as well.

        """
        shutil.copyfileobj(source, outputfile)

    def guess_type(self, path):
        """Guess the type of a file.

        Argument is a PATH (a filename).

        Return value is a string of the form type/subtype,
        usable for a MIME Content-type header.

        The default implementation looks the file's extension
        up in the table self.extensions_map, using application/octet-stream
        as a default; however it would be permissible (if
        slow) to look inside the data to make a better guess.

        """

        base, ext = posixpath.splitext(path)
        if ext in self.extensions_map:
            return self.extensions_map[ext]
        ext = ext.lower()
        if ext in self.extensions_map:
            return self.extensions_map[ext]
        else:
            return self.extensions_map['']

    @staticmethod
    def update_mimtypes_map():
        if not mimetypes.inited:
            mimetypes.init()  # try to read system mime.types
        extensions_map = mimetypes.types_map.copy()
        extensions_map.update({
            '': 'application/octet-stream',  # Default
            '.py': 'text/plain',
            '.c': 'text/plain',
            '.h': 'text/plain',
        })


DMaaPHandler.update_mimtypes_map()
