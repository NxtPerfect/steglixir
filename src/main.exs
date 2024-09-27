import Bitwise

defmodule Steglixir do
  @spec encrypt(String, String) :: :ok
  def encrypt(sourcePath, destinationPath)
      when is_number(sourcePath) or is_nil(sourcePath) or is_number(destinationPath) or
             is_nil(destinationPath),
      do: "Path argument is empty or not a string"

  @spec encrypt(String, String) :: :ok
  def encrypt(sourcePath, destinationPath) do
    if not File.exists?(sourcePath) or File.dir?(sourcePath) do
      IO.puts("Source path doesn't exist or is a folder.")
      :error
    end

    if File.dir?(destinationPath) do
      IO.puts("Destination path be a file, not a folder.")
      :error
    end

    {status, unencryptedFile} = File.read(sourcePath)

    if status != :ok do
      IO.puts("Failed to read file. Check permissions.")
      :error
    end

    [newRed, newGreen, newBlue] = divideFileToPixelsAndEncryptMessage(unencryptedFile, "Msg")
    # green = green(& 1)
    # blue = blue(& 1)
    # testFile = <<red, green, blue>>
    # IO.inspect([red, green, blue])
    # IO.inspect(testFile)
    IO.inspect([newRed, newGreen, newBlue])
  end

  def decrypt(sourcePath, destinationPath) do
    _newPath = sourcePath
    _newPp = destinationPath
    :ok
  end

  @spec(divideFileToPixelsAndEncryptMessage(Binary, String) :: Binary, Binary, Binary)
  defp divideFileToPixelsAndEncryptMessage(unencryptedFile, message) do
    <<rgb::binary-size(3), _restOfUnencryptedFile::binary>> = unencryptedFile
    <<red::binary-size(1), green::binary-size(1), blue::binary-size(1)>> = rgb
    IO.inspect([red, green, blue])

    # <<binaryMessage::utf8>> = message

    # intMessageFirst = Enum.at(binaryMessage, 0)
    <<firstChar::binary-size(1), _restOfIntMessageFirst::binary>> = message
    # IO.inspect(<<intMessageFirst::binary>>)

    newRed = embedMessageIntoPixelColorChannel(firstChar, red)
    newGreen = embedMessageIntoPixelColorChannel(firstChar, green)
    newBlue = embedMessageIntoPixelColorChannel(firstChar, blue)
    [newRed, newGreen, newBlue]
  end

  @spec embedMessageIntoPixelColorChannel(Binary, Binary) :: Binary
  defp embedMessageIntoPixelColorChannel(message, colorChannel) do
    <<colorChannelFirstSevenBits::size(7), colorChannelLastBit::size(1)>> = colorChannel
    IO.puts(colorChannelLastBit)
    colorChannelChangedLastBit = colorChannelLastBit &&& message
    IO.puts(colorChannelChangedLastBit)

    <<colorChannelFirstSevenBits::size(7), colorChannelChangedLastBit::size(1)>>
  end
end

Steglixir.encrypt("data/test.jpg", "data/encryptedTest.jpg")
Steglixir.decrypt("data/encryptedTest.jpg", "data/unencryptedTest.jpg")
