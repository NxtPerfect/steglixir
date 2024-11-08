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

    # IO.puts("Message before encoding:")
    # IO.inspect(message)

    binaryMessage = convertMessageToBinary(message)

    # IO.puts("Message after converting to binary:")
    # IO.inspect(binaryMessage)

    [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
      divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

    # IO.inspect([newRed, newGreen, newBlue])

    tempEncryptedFile = newRed <> newGreen <> newBlue

    finalEncryptedFile =
      encryptUntilFinished(restOfFile, restOfBinaryMessage, tempEncryptedFile)

    File.write(destinationPath, finalEncryptedFile)
    finalEncryptedFile
  end

  @spec(divideFileToPixelsAndEncryptMessage(Binary, Integer) :: Binary, Binary, Binary, Binary)
  defp divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)
       when Kernel.length(binaryMessage) >= 3 do
    <<rgb::binary-size(3), restOfUnencryptedFile::binary>> = unencryptedFile
    <<red::binary-size(1), green::binary-size(1), blue::binary-size(1)>> = rgb
    # IO.inspect([red, green, blue], label: "RGB")
    # IO.puts("Binary message to encode:")
    # IO.inspect(binaryMessage, label: "Binary message")

    [firstBit, secondBit, thirdBit | restOfBinaryMessage] = binaryMessage

    newRed = embedMessageIntoPixelColorChannel(firstBit, red)
    newGreen = embedMessageIntoPixelColorChannel(secondBit, green)
    newBlue = embedMessageIntoPixelColorChannel(thirdBit, blue)
    [newRed, newGreen, newBlue, restOfUnencryptedFile, restOfBinaryMessage]
  end

  defp convertMessageToBinary(message) do
    char_codes = String.to_charlist(message)

    bin_list =
      Enum.map(char_codes, fn char ->
        char
        # |> IO.inspect(label: "Char to bin")
        |> Integer.digits(2)
        |> isSevenBitsInLength()
      end)

    binaryMessage = List.flatten(bin_list)
    # IO.inspect(binaryMessage, label: "Encoded binary message")
    binaryMessage
  end

  defp isSevenBitsInLength(charList) when Kernel.length(charList) == 7 do
    charList
  end

  defp isSevenBitsInLength(charList) do
    correctLengthList =
      Enum.join(charList)
      |> String.pad_leading(7, "0")
      # |> IO.inspect(label: "Number after padding")
      |> String.graphemes()
      # |> IO.inspect(label: "Graphemes")
      |> Enum.map(fn char ->
        char
        |> Integer.parse(2)
        |> Kernel.elem(0)
      end)

    # |> IO.inspect(label: "Parsing")
    correctLengthList
  end

  defp divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)
       when Kernel.length(binaryMessage) == 2 do
    <<rgb::binary-size(3), restOfUnencryptedFile::binary>> = unencryptedFile
    <<red::binary-size(1), green::binary-size(1), blue::binary-size(1)>> = rgb
    # IO.inspect([red, green, blue])
    # IO.puts("Binary message to encode:")
    # IO.inspect(binaryMessage)

    [firstBit, secondBit | restOfBinaryMessage] = binaryMessage
    thirdBit = 0

    newRed = embedMessageIntoPixelColorChannel(firstBit, red)
    newGreen = embedMessageIntoPixelColorChannel(secondBit, green)
    newBlue = embedMessageIntoPixelColorChannel(thirdBit, blue)
    [newRed, newGreen, newBlue, restOfUnencryptedFile, restOfBinaryMessage]
  end

  defp divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)
       when Kernel.length(binaryMessage) == 1 do
    <<rgb::binary-size(3), restOfUnencryptedFile::binary>> = unencryptedFile
    <<red::binary-size(1), green::binary-size(1), blue::binary-size(1)>> = rgb
    # IO.inspect([red, green, blue])
    # IO.puts("Binary message to encode:")
    # IO.inspect(binaryMessage)

    [firstBit | restOfBinaryMessage] = binaryMessage
    secondBit = 0
    thirdBit = 0

    newRed = embedMessageIntoPixelColorChannel(firstBit, red)
    newGreen = embedMessageIntoPixelColorChannel(secondBit, green)
    newBlue = embedMessageIntoPixelColorChannel(thirdBit, blue)
    [newRed, newGreen, newBlue, restOfUnencryptedFile, restOfBinaryMessage]
  end

  @spec embedMessageIntoPixelColorChannel(Binary, Binary) :: Binary
  defp embedMessageIntoPixelColorChannel(message, colorChannel) do
    <<colorChannelFirstSevenBits::size(7), colorChannelLastBit::size(1)>> = colorChannel
    # IO.puts(colorChannelLastBit)
    colorChannelChangedLastBit = colorChannelLastBit &&& message
    # IO.puts(colorChannelChangedLastBit)

    <<colorChannelFirstSevenBits::size(7), colorChannelChangedLastBit::size(1)>>
  end

  @spec encryptUntilFinished(Bitwise, List, Bitwise) :: Bitwise
  defp encryptUntilFinished(unencryptedFile, preBinaryMessage, encryptedFile)
       when Kernel.length(preBinaryMessage) == 0 do
    message = "\\0"
    binaryMessage = convertMessageToBinary(message)

    [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
      divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

    newEncryptedFile = encryptedFile <> newRed <> newGreen <> newBlue

    finalEncryptedFile =
      encryptUntilFinished(restOfFile, restOfBinaryMessage, newEncryptedFile, true)

    finalEncryptedFile
  end

  defp encryptUntilFinished(unencryptedFile, preBinaryMessage, encryptedFile)
       when Kernel.length(preBinaryMessage) == 1 do
    binaryMessage = preBinaryMessage ++ [0, 0]

    [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
      divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

    newEncryptedFile = encryptedFile <> newRed <> newGreen <> newBlue
    finalEncryptedFile = encryptUntilFinished(restOfFile, restOfBinaryMessage, newEncryptedFile)
    finalEncryptedFile
  end

  defp encryptUntilFinished(unencryptedFile, preBinaryMessage, encryptedFile)
       when Kernel.length(preBinaryMessage) == 2 do
    binaryMessage = [preBinaryMessage, 0]

    [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
      divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

    newEncryptedFile = encryptedFile <> newRed <> newGreen <> newBlue

    finalEncryptedFile =
      encryptUntilFinished(restOfFile, restOfBinaryMessage, newEncryptedFile)

    finalEncryptedFile
  end

  defp encryptUntilFinished(unencryptedFile, preBinaryMessage, encryptedFile) do
    # IO.puts("Binary length not 0, 1 or 2, returning")
    binaryMessage = preBinaryMessage

    [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
      divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

    newEncryptedFile = encryptedFile <> newRed <> newGreen <> newBlue

    finalEncryptedFile =
      encryptUntilFinished(restOfFile, restOfBinaryMessage, newEncryptedFile)

    finalEncryptedFile
  end

  @spec encryptUntilFinished(Bitwise, List, Bitwise, boolean) :: Bitwise
  defp encryptUntilFinished(unencryptedFile, _preBinaryMessage, encryptedFile, _endingSymbol)
       when Kernel.length(_preBinaryMessage) == 0 and _endingSymbol do
    # IO.inspect(encryptedFile)
    # IO.inspect(unencryptedFile)
    IO.puts("Message encrypted into file. Concatenating rest of unencrypted file.")
    finalEncryptedFile = encryptedFile <> unencryptedFile
    finalEncryptedFile
  end

  defp encryptUntilFinished(unencryptedFile, preBinaryMessage, encryptedFile, endingSymbol)
       when endingSymbol do
    binaryMessage = preBinaryMessage

    [newRed, newGreen, newBlue, restOfFile, restOfBinaryMessage] =
      divideFileToPixelsAndEncryptMessage(unencryptedFile, binaryMessage)

    newEncryptedFile = encryptedFile <> newRed <> newGreen <> newBlue

    finalEncryptedFile =
      encryptUntilFinished(restOfFile, restOfBinaryMessage, newEncryptedFile, true)

    finalEncryptedFile
  end

  @spec decrypt(String) :: :ok
  def decrypt(sourcePath) do
    encryptedFile = File.read!(sourcePath)
    <<firstCharColorCanals::binary-size(7), _restOfEncryptedFile::binary>> = encryptedFile
    IO.inspect(<<decryptUntilFinished(firstCharColorCanals, [])>>, label: "Decrypted message")
    :ok
  end

  @spec decryptUntilFinished(String, String) :: String
  defp decryptUntilFinished(fileContent, message) when byte_size(fileContent) > 7 do
    listOfDecryptedMessage = decrypt(fileContent, [])
    <<_::7, restOfFileContent::binary>> = fileContent
    IO.inspect(decryptUntilFinished(restOfFileContent, [], listOfDecryptedMessage))
  end

  defp decryptUntilFinished(fileContent, message) when byte_size(fileContent) == 7 do
    IO.puts("Only 7 channels left, returning list of string.")
    listOfDecryptedMessage = decrypt(fileContent, [])
    listOfDecryptedMessage
  end

  defp decryptUntilFinished(fileContent, message, listOfDecryptedMessage) do
    newListOfDecryptedMessage =
      [decrypt(fileContent, []) | listOfDecryptedMessage] |> Enum.reverse()

    newListOfDecryptedMessage
  end

  @spec decrypt(Binary, List) :: String
  defp decrypt(fileContent, listOfBits) when length(listOfBits) != 7 do
    <<colorChanel::binary-size(1), restOfFile::binary>> = fileContent
    reversedColorChanel = reverseColorChannel(colorChanel)
    <<leastSignificantBit::size(1), _::size(7)>> = reversedColorChanel
    newListOfBits = [leastSignificantBit | listOfBits]
    decrypt(restOfFile, newListOfBits)
  end

  @spec decrypt(Binary, List) :: String
  defp decrypt(_, listOfBits) when length(listOfBits) == 7 do
    IO.puts("Forming a list from bits")

    listOfBits
    |> Enum.reverse()
    |> Integer.undigits(2)
  end

  defp reverseColorChannel(colorChannel) do
    colorChannel
    |> :binary.bin_to_list()
    |> Enum.reverse()
    |> :binary.list_to_bin()
  end
end

Steglixir.encrypt("data/test.jpg", "data/encryptedTest.jpg", "Hello, World!")
Steglixir.decrypt("data/encryptedTest.jpg")
