# HappyFinderWrapper
# [![Build Status Appveyor](https://ci.appveyor.com/api/projects/status/msadwx4mm48kfk20?svg=true)](https://ci.appveyor.com/project/kelleyma49/happyfinderwrapper) [![MIT licensed](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/kelleyma49/HappyFinderWrapper/blob/master/LICENSE)

HappyFinderWrapper is a PowerShell module that wraps [HappyFinder](https://github.com/hugows/hf), a fuzzy file finder for the command line.  HappyFinder contains a subset of the features available in the popular finder [fzf](https://github.com/junegunn/fzf).

![](https://raw.github.com/kelleyma49/HappyFinderWrapper/master/HfwDemonstration.gif)

# Installation
HappyFinderWrapper is available on the [PowerShell Gallery](https://www.powershellgallery.com/packages/HappyFinderWrapper).  PSReadline should be imported before HappyFinderWrapper as HappyFinderWrapper registers <kbd>CTRL+T</kbd> as a PSReadline key handler.

HappyFinderWrapper has only been tested on PowerShell 5.0.

# Usage
Press <kbd>CTRL+T</kbd> to start HappyFinder.  HappyFinderWrapper will parse the current token and use that as the starting path to search from.  If current token is empty, or the token isn't a valid path, HappyFinderWrapper will search below the current working directory.  

Multiple items can be selected in HappyFinder.  If more than one it is selected by the user, the results are returned as a comma separated list.  Results are properly quoted if they contain whitespace.

