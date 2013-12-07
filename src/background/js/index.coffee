
do ->
  bg = Background.getInstance()
  chrome.app.runtime.onLaunched.addListener bg.onLauncher.bind(bg)
  
