module HelloSample
  def say_hello(name)
    "Hello, #{name}!"
  end

  def error(*args)
    raise "Something went wrong"
  end
end
