local sp = require "packages/sp/sp"
local sp_star = require "packages/sp/sp_star"
local sp_cards = require "packages/sp/sp_cards"
local sp_jsp = require "packages/sp/sp_jsp"
local sp_re = require "packages/sp/sp_re"

Fk:loadTranslationTable(require 'packages/sp/i18n/en_US', 'en_US')

return {
  sp,
  sp_star,
  sp_cards,
  sp_jsp,
  sp_re,
}
