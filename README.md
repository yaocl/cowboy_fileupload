# cowboy fileupload sample

Cowboy 0.9 release and master branch support different multipart request data processing APIs. Cowboy is a good erlang http library. But the author did not provide enough sample projects and user guides about http file upload processing.

This sample project provides a http file upload sample.

Reference to the user guide [cowboy multipart request manual](https://github.com/extend/cowboy/blob/master/guide/multipart_req.md) in cowboy master branch.

# Compile and Run

This sample followed up cowboy sample project packaging rules.

1. clone this project
	```
	> git clone https://github.com/yaocl/cowboy_fileupload.git
	```

2. compilation
	```
	> make
	```
	It will get the dependent projects including cowboy, cowlib, ranch and the tool relx.

3. run
	```
	> _rel/bin/upload_example console
	```

4. testing
	browse the web page http://localhost:8000/
