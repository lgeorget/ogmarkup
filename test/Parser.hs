{-# LANGUAGE OverloadedStrings #-}

module Parser where

import           Data.Either
import           Data.Text                     (Text)
import           Test.Hspec
import           Text.ParserCombinators.Parsec

import qualified Text.Ogmarkup.Private.Ast     as Ast
import qualified Text.Ogmarkup.Private.Parser  as Parser

shouldParse x b = x `shouldBe` Right b

shouldFail x = x `shouldSatisfy` isLeft

parserSpec :: Spec
parserSpec = describe "atom" $ do
    it "should not parse an empty string" $ shouldFail (parse Parser.atom "" "")

    it "should parse one word" $ parse Parser.atom "" hiStr `shouldParse` hiAtom

    it "should parse one punctuation mark" $
      parse Parser.atom "" exclamationStr `shouldParse` exclamationAtom

    it "should parse one quote" $
      parse Parser.collection "" quoteStr `shouldParse` quoteCollection

    it "should fail if the quote is ill-formed (no closing quote)" $
      shouldFail (parse Parser.collection "" illQuoteStr)

    it "should parse a raw collection" $
      parse Parser.format "" rawStr `shouldParse` rawFormat

    it "should parse an emphasis collection with no space" $
      parse Parser.format "" emphStrNoSpace `shouldParse` emphFormat

    it "should parse an emphasis collection with some spaces" $
      parse Parser.format "" emphStrSpace `shouldParse` emphFormat

    it "should fail if it encounters a blank line" $
      shouldFail (parse Parser.format "" emphStrEndOfParagraph)

    it "should parse a strongly emphasis collection with no space" $
      parse Parser.format "" strongEmphStrNoSpace `shouldParse` strongEmphFormat

    it "should parse a strongly emphasis collection with some spaces" $
      parse Parser.format "" strongEmphStrSpace `shouldParse` strongEmphFormat

    it "should fail if it encounters a blank line" $
      shouldFail (parse Parser.format "" strongEmphStrEndOfParagraph)

hiStr = "hi"
hiAtom = Ast.Word "hi"

exclamationStr = "!"
exclamationAtom = Ast.Punctuation Ast.Exclamation

quoteStr = "«hi everyone.»"
quoteCollection = Ast.Quote [hiAtom, Ast.Word "everyone", Ast.Punctuation Ast.Point]

illQuoteStr = "«hi"

formatStr = "hi.. \"everyone\"."
formatCollection = [Ast.Text [Ast.Word "hi", Ast.Punctuation Ast.SuspensionPoints],
                    Ast.Quote [Ast.Word "everyone"],
                    Ast.Text [Ast.Punctuation Ast.Point]]

rawStr = formatStr
rawFormat = Ast.Raw formatCollection

emphStrNoSpace = "*" ++ formatStr ++ "*"
emphStrSpace = "* " ++ formatStr ++ "  *"
emphStrEndOfParagraph = "* " ++ formatStr ++ "\n\n*"
emphFormat = Ast.Emph formatCollection

strongEmphStrNoSpace = "+" ++ formatStr ++ "+"
strongEmphStrSpace = "+ " ++ formatStr ++ "  +"
strongEmphStrEndOfParagraph = "+ " ++ formatStr ++ "\n\n+"
strongEmphFormat = Ast.StrongEmph formatCollection
