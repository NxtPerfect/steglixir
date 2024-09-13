defmodule Steglixir do
  @spec encrypt(String, String) :: :ok
  def encrypt(sourcePath, destinationPath)
      when is_number(sourcePath) or is_nil(sourcePath) or is_number(destinationPath) or
             is_nil(destinationPath),
      do: "Path argument is empty or not a string"

  def encrypt(sourcePath, destinationPath) do
    if not File.exists?(sourcePath) or File.dir?(sourcePath) do
      IO.puts("Source path doesn't exist or is a folder.")
      :error
    end

    if File.dir?(destinationPath) do
      IO.puts("Destination path is a folder.")
      :error
    end

    {status, unencryptedFile} = File.read(sourcePath)

    if status != :ok do
      IO.puts("Failed to read file. Check permissions.")
      :error
    end

    <<rgb::binary-size(3), _restOfUnencryptedFile::binary>> = unencryptedFile
    <<red::binary-size(1), green::binary-size(1), blue::binary-size(1)>> = rgb
    IO.inspect([red, green, blue])
    red = red(& 1)
    green = green(& 1)
    blue = blue(& 1)
    testFile = <<red, green, blue>>
    IO.inspect([red, green, blue])
    IO.inspect(testFile)
  end

  def decrypt(sourcePath, destinationPath) do
    _newPath = sourcePath
    _newPp = destinationPath
    :ok
  end
end

Steglixir.encrypt("data/test.jpg", "data/encryptedTest.jpg")
Steglixir.decrypt("data/encryptedTest.jpg", "data/unencryptedTest.jpg")
