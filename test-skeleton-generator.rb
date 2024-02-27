require 'openai'

class RubyTestSkeletonGenerator
  def initialize(read_file_path, write_file_path)
    @read_file_path = read_file_path
    @write_file_path = write_file_path
  end

  def generate_test_skeletons
    read_file_contents = read_file_contents_without_comments

    class_name = extract_class_name
    file_name = File.basename(@read_file_path).split(/[.]/)[0]

      File.open("../#{@write_file_path}/#{file_name}_spec.rb", "w") do |write_file|

      write_file.puts("describe #{class_name} do\n")

      generate_method_tests(read_file_contents, write_file)

      write_file.puts("\nend") # end main method
    end
  end

  private

  def read_file_contents_without_comments
    read_file_contents = ""
    File.open("./#{@read_file_path}", "r") do |file|
      file.each_line do |line|
        next if line.match?("#") && line.match?(/def\s/)
        next if line.match?("#") && line.match?(/end\s/)
        read_file_contents << line
      end
    end
    read_file_contents

  end

  def extract_class_name
    read_file = File.open("./#{@read_file_path}", "r")

    class_name_line = read_file.find do |line|
      line =~ /^\s*(class|module)\b/ && !line.start_with?('#')
    end

    class_name_tokens = class_name_line.split(/\s+/)

    if class_name_tokens.include?("class")
      return class_name_tokens[class_name_tokens.find_index("class") + 1]
    else class_name_tokens.include?("module")
      return class_name_tokens[class_name_tokens.find_index("module") + 1]
    end
  end

  def generate_method_tests(read_file_contents, write_file)
    read_file_contents.scan(/^(?:(?!#).)*def (.*?)[\n\(\?\;]/).each do |method_name|
      method_name = method_name.to_s.delete(']["').gsub(/\(.*?\)/, '').strip
      method_body_lines = read_file_contents.match(/def #{method_name}[\n\(\?\;](.*?)def /m)
      method_body_lines = read_file_contents.match(/def #{method_name}[\n\(\?\;](.*)end/m) if method_body_lines.nil?
      method_body_lines = method_body_lines.to_s.strip
      method_body = method_body_lines.match(/(.*)end/m).to_s.strip

      if method_body.empty?
        write_file.puts("describe \"#{method_name}\" do\n #Please look at the source code before writing tests. There are possible errors in your code.'\nend\n" )
      else
        sleep(20) # Wait 20 seconds to circumvent OpenAI's 3 requests/min restriction.
        test_body = generate_test_body(method_body)
        write_file.puts(test_body)
      end
    end
  end

  def generate_test_body(method_body)
    client = OpenAI::Client.new(access_token: 'ADD API KEY HERE')
    response = client.chat(
      parameters: {
        model: "gpt-3.5-turbo-16k",
        messages: [{ role: "user", content: " #{method_body}\n create test scenarios with method names and descriptions for the given Ruby method, organized in a spec file format. Do not include any extension of test bodies. Do not include Rspec line at the beginning"}],
        temperature: 0,
      })

    if response.dig("choices", 0, "message", "content").nil?
      "Please look at the source code before writing tests. Unable to explain the method.\n  end\n"
    else
      response.dig("choices", 0, "message", "content")
    end
  end
end

# Usage
read_file_path = ARGV[0]
write_file_path = ARGV[1]

puts "Generating test skeletons... Please be patient."

generator = RubyTestSkeletonGenerator.new(read_file_path, write_file_path)
generator.generate_test_skeletons

puts "The Generator is complete! Check the spec file created"
