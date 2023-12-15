Test Skeleton Generator
=========


#### How to Run

* You will need to create an OpenAI account to connect the API, use the link below.
* https://platform.openai.com/signup
* You will need a API Key to connect the API, log in your account and go settings.
* Once you create a API Key, please add it into "ADD API KEY HERE" in the source code of the generator.

First, you need to install openai gem: `gem install ruby-openai`

To run the test skeleton generator: run the code below at the terminal
ruby test-skeleton-generator.rb {file_name} {dest_path}

Example: `ruby test-skeleton-generator.rb  controller_sample.rb test-skeleton-generator`

* file_name: This is the file which you would like to create test skeletons from.
* dest_path: This is the destination path which you would like to save the spec file at

* file_name = controller_sample.rb
* dest_path = test-skeleton-generator

### How it Works

* Test-Skeleton Generator reads the file to be tested and examines the classes, modules and methods in it.
* To create test skeletons, it ask question with dedicated promps to OpenAI API, and collect the answers.
* It creates test skeletons in a spec file according to the methods.
* You will see the spec file at the specific path aimed to save it.



### Notes

* You can see auto-generated test skeletons in controller_sample_spec.rb

* Sometimes OpenAI API unable to response the description of the methods. In this case you will see the attention in the description of the method

* Attention: "Please look at the source code before writing tests. Unable to explain the method."

* When you see the attention like above, you should look at the source code and write the tests manually.


### Future Works

OpenAI API is working with gpt-3.5 extension. With the help of the gpt-4 API and other novel models which will be available soon, it will be more reliable to get description of the methods.
