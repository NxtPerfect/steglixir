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

    unencryptedFile = File.read!(sourcePath)

    binaryMessage = Integer.digits(:binary.first(message), 2)

    [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
      divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

    IO.inspect([newRed, newGreen, newBlue])

    tempEncryptedFile = [newRed, newGreen, newBlue, restOfFile]

    finalEncryptedFile =
      encryptUntilFinished(unencryptedFile, restOfBinaryMessage, tempEncryptedFile)

    File.write(destinationPath, finalEncryptedFile)
    finalEncryptedFile
  end

  defp encryptUntilFinished(unencryptedFile, preBinaryMessage, encryptedFile)
       when Kernel.length(preBinaryMessage) == 0 do
    if Kernel.length(preBinaryMessage) == 0 do
      resultingFile = encryptedFile ++ unencryptedFile
      resultingFile
    end

    # If message has less than three bits
    if Kernel.length(preBinaryMessage) == 1 do
      binaryMessage = preBinaryMessage ++ [0, 0]

      [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
        divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

      newEncryptedFile = [encryptedFile, newRed, newGreen, newBlue]
      finalEncryptedFile = encryptUntilFinished(restOfFile, restOfBinaryMessage, newEncryptedFile)
      finalEncryptedFile
    else
      if Kernel.length(preBinaryMessage) == 2 do
        binaryMessage = [preBinaryMessage, 0]

        [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
          divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

        newEncryptedFile = [encryptedFile, newRed, newGreen, newBlue]

        finalEncryptedFile =
          encryptUntilFinished(restOfFile, restOfBinaryMessage, newEncryptedFile)

        finalEncryptedFile
      else
        binaryMessage = preBinaryMessage

        [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
          divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

        newEncryptedFile = [encryptedFile, newRed, newGreen, newBlue]

        finalEncryptedFile =
          encryptUntilFinished(restOfFile, restOfBinaryMessage, newEncryptedFile)

        finalEncryptedFile
      end
    end
  end

  def decrypt(sourcePath, destinationPath) do
    _newPath = sourcePath
    _newPp = destinationPath
    :ok
  end

  @spec(divideFileToPixelsAndEncryptMessage(Binary, Integer) :: Binary, Binary, Binary, Binary)
  defp divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage) do
    <<rgb::binary-size(3), restOfUnencryptedFile::binary>> = unencryptedFile
    <<red::binary-size(1), green::binary-size(1), blue::binary-size(1)>> = rgb
    IO.inspect([red, green, blue])

    [firstBit, secondBit, thirdBit | restOfBinaryMessage] = binaryMessage

    newRed = embedMessageIntoPixelColorChannel(firstBit, red)
    newGreen = embedMessageIntoPixelColorChannel(secondBit, green)
    newBlue = embedMessageIntoPixelColorChannel(thirdBit, blue)
    [newRed, newGreen, newBlue, restOfUnencryptedFile, restOfBinaryMessage]
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
