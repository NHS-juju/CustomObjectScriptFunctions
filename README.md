# CustomObjectScriptFunctions
Curated class of Custom Functions used for Intersystems IRIS

Submit bug reports and feature suggestions under the [issues tab](https://github.com/NHS-juju/CustomObjectScriptFunctions/issues) in github.

## Installation
Currently, the only option for install is to import the class file into your environment either from the management portal, from the IRIS terminal, or other methods of importing classes.

## FAQ

**Q: Why does this exist?**

**A:** I found myself relying on some of the same custom functions between various namespaces in environments I work/worked with. Rather than repetitively re-inventing the wheel, I decided to move it all into this project.

**Q: Some of these functions feel familiar?**

**A:** Some of these have come from their appearance on the developer community or from the online documentation (either directly or inspired by). Where this is the case, every effort will be made to mention this alongside the code. Please [raise an issue](https://github.com/NHS-juju/CustomObjectScriptFunctions/issues) if you find an example where this hasn't happened and you believe it should be.

**Q: There is not much to see. Why is this?**

**A:** I'm building this up from various internal sources, and attempting to exclude any that are too single-use or very bespoke for an issue. For example, I have included quite a few Date/Day based functions that I have used across multiple environments for alerting rules, however I have excluded a function from the same source that exists to return `false` if the HL7 message the function is evaluating came from `System X` as this is too specific.
