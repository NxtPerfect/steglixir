import Bitwise

defmodule Steglixir do
  @spec encrypt(String, String, String) :: :ok
  def encrypt(sourcePath, destinationPath, message)
      when is_number(sourcePath) or is_nil(sourcePath) or is_number(destinationPath) or
             is_nil(destinationPath) or is_number(message) or is_nil(message),
      do: "Path argument is empty or not a string"

  @spec encrypt(String, String, String) :: :ok
  def encrypt(sourcePath, destinationPath, message) when is_binary(message) do
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

    [newRed, newGreen, newBlue, restOfFile] =
      divideFileToPixelsAndEncryptMessage(unencryptedFile, "Msg")

    IO.inspect([newRed, newGreen, newBlue])
    encryptedFile = [newRed, newGreen, newBlue, restOfFile]
    File.write(destinationPath, encryptedFile)
    encryptedFile
  end

  def decrypt(sourcePath, destinationPath) do
    _newPath = sourcePath
    _newPp = destinationPath
    :ok
  end

  @spec(divideFileToPixelsAndEncryptMessage(Binary, String) :: Binary, Binary, Binary, Binary)
  defp divideFileToPixelsAndEncryptMessage(unencryptedFile, message) do
    binaryMessage = :binary.first(message)
    <<rgb::binary-size(3), restOfUnencryptedFile::binary>> = unencryptedFile
    <<red::binary-size(1), green::binary-size(1), blue::binary-size(1)>> = rgb
    IO.inspect([red, green, blue])

    # <<binaryMessage::utf8>> = message

    [firstBit, secondBit, thirdBit | _restOfIntMessageFirst] = Integer.digits(binaryMessage, 2)

    newRed = embedMessageIntoPixelColorChannel(firstBit, red)
    newGreen = embedMessageIntoPixelColorChannel(secondBit, green)
    newBlue = embedMessageIntoPixelColorChannel(thirdBit, blue)
    [newRed, newGreen, newBlue, restOfUnencryptedFile]
  end

  @spec embedMessageIntoPixelColorChannel(Binary, Binary) :: Binary
  defp embedMessageIntoPixelColorChannel(message, colorChannel) do
    <<colorChannelFirstSevenBits::size(7), colorChannelLastBit::size(1)>> = colorChannel
    IO.puts(colorChannelLastBit)
    colorChannelChangedLastBit = colorChannelLastBit &&& message
    IO.puts(colorChannelChangedLastBit)

    <<colorChannelFirstSevenBits::size(7), colorChannelChangedLastBit::size(1)>>
  end

  @spec readMessage(String) :: String
  def readMessage(message) do
    IO.puts(message)
  end
end

Steglixir.encrypt("data/test.jpg", "data/encryptedTest.jpg", "Hello, World!")
Steglixir.readMessage("data/encryptedTest.jpg")
Steglixir.decrypt("data/encryptedTest.jpg", "data/unencryptedTest.jpg")
IO.puts("data/unencryptedTest.jpg" == "data/test.jpg")
