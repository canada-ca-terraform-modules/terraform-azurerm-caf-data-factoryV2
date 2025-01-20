locals {
  name_regex = "/[//\"'\\[\\]:|<>+=;,?*@&]/" # Can't include those characters  name: \/"'[]:|<>+=;,?*@&
  env_4                         = substr(var.env, 0, 4)
  userDefinedString_7           = substr(var.userDefinedString, 0, 7)
  data-factory-name                 = lower(replace("${local.env_4}-${local.userDefinedString_7}-df", local.name_regex, ""))

}