def pbChooseLanguage
  commands=[]
  for lang in LANGUAGES
    commands.push(lang[0])
  end
  return aaaSaveLanguage(Kernel.pbShowCommands(nil,commands)) #####MODDED, was return Kernel.pbShowCommands(nil,commands)
end

#####MODDED
def aaaSaveLanguage(iLang)
  file = File.open(RTP.getSaveFileName("Default_Language.rxdata"),"wb")
  file.seek(0)
  file.write(iLang)
  file.close
  
  return iLang
end

def aaaLoadLanguage
  if safeExists?(RTP.getSaveFileName("Default_Language.rxdata"))
    file = File.open(RTP.getSaveFileName("Default_Language.rxdata"))
    file.seek(0)
    sLang = file.readline
    iLang = sLang.to_i
    file.close
    
    if iLang < LANGUAGES.length
      $PokemonSystem.language = iLang
      pbLoadMessages("Data/"+LANGUAGES[$PokemonSystem.language][1])
    end
  end
end

aaaLoadLanguage
#####/MODDED

#Fix an issue with translated keybindings; just remove _INTL
module Keys  
  # Available keys
  CONTROLSLIST = {
    # Mouse buttons
    "Backspace" => 0x08,
    "Tab" => 0x09,
    "Clear" => 0x0C,
    "Enter" => 0x0D,
    "Shift" => 0x10,
    "Ctrl" => 0x11,
    "Alt" => 0x12,
    "Pause" => 0x13,
    "Caps Lock" => 0x14,
    # IME keys
    "Esc" => 0x1B,
    # More IME keys
    "Space" => 0x20,
    "Page Up" => 0x21,
    "Page Down" => 0x22,
    "End" => 0x23,
    "Home" => 0x24,
    "Left" => 0x25,
    "Up" => 0x26,
    "Right" => 0x27,
    "Down" => 0x28,
    "Select" => 0x29,
    "Print" => 0x2A,
    "Execute" => 0x2B,
    "Print Screen" => 0x2C,
    "Insert" => 0x2D,
    "Delete" => 0x2E,
    "Help" => 0x2F,
    "0" => 0x30,
    "1" => 0x31,
    "2" => 0x32,
    "3" => 0x33,
    "4" => 0x34,
    "5" => 0x35,
    "6" => 0x36,
    "7" => 0x37,
    "8" => 0x38,
    "9" => 0x39,
    "A" => 0x41,
    "B" => 0x42,
    "C" => 0x43,
    "D" => 0x44,
    "E" => 0x45,
    "F" => 0x46,
    "G" => 0x47,
    "H" => 0x48,
    "I" => 0x49,
    "J" => 0x4A,
    "K" => 0x4B,
    "L" => 0x4C,
    "M" => 0x4D,
    "N" => 0x4E,
    "O" => 0x4F,
    "P" => 0x50,
    "Q" => 0x51,
    "R" => 0x52,
    "S" => 0x53,
    "T" => 0x54,
    "U" => 0x55,
    "V" => 0x56,
    "W" => 0x57,
    "X" => 0x58,
    "Y" => 0x59,
    "Z" => 0x5A,
    # Windows keys
    "Numpad 0" => 0x60,
    "Numpad 1" => 0x61,
    "Numpad 2" => 0x62,
    "Numpad 3" => 0x63,
    "Numpad 4" => 0x64,
    "Numpad 5" => 0x65,
    "Numpad 6" => 0x66,
    "Numpad 7" => 0x67,
    "Numpad 8" => 0x68,
    "Numpad 9" => 0x69,
    "Multiply" => 0x6A,
    "Add" => 0x6B,
    "Separator" => 0x6C,
    "Subtract" => 0x6D,
    "Decimal" => 0x6E,
    "Divide" => 0x6F,
    "F1" => 0x70,
    "F2" => 0x71,
    "F3" => 0x72,
    "F4" => 0x73,
    "F5" => 0x74,
    "F6" => 0x75,
    "F7" => 0x76,
    "F8" => 0x77,
    "F9" => 0x78,
    "F10" => 0x79,
    "F11" => 0x7A,
    "F12" => 0x7B,
    "F13" => 0x7C,
    "F14" => 0x7D,
    "F15" => 0x7E,
    "F16" => 0x7F,
    "F17" => 0x80,
    "F18" => 0x81,
    "F19" => 0x82,
    "F20" => 0x83,
    "F21" => 0x84,
    "F22" => 0x85,
    "F23" => 0x86,
    "F24" => 0x87,
    "Num Lock" => 0x90,
    "Scroll Lock" => 0x91,
    # Multiple position Shift, Ctrl and Menu keys
    ";:" => 0xBA,
    "+" => 0xBB,
    "," => 0xBC,
    "-" => 0xBD,
    "." => 0xBE,
    "/?" => 0xBF,
    "`~" => 0xC0,
    "{" => 0xDB,
    "\|" => 0xDC,
    "}" => 0xDD,
    "'\"" => 0xDE,
    "AX" => 0xE1, # Japan only
    "\|" => 0xE2
    # Disc keys
  }
  
  # Here you can change the number of keys for each action and the
  # default values
  def self.defaultControls
    return [
      ControlConfig.new("Down","Down"),
      ControlConfig.new("Left","Left"),
      ControlConfig.new("Right","Right"),
      ControlConfig.new("Up","Up"),
      ControlConfig.new("Action","Z"),
      ControlConfig.new("Action","C"),
      ControlConfig.new("Action","Enter"),
      ControlConfig.new("Action","Space"),
      ControlConfig.new("Cancel/Menu","X"),
      ControlConfig.new("Cancel/Menu","Esc"),
      ControlConfig.new("Run","Space"),
      ControlConfig.new("Scroll down","Page Down"),
      ControlConfig.new("Scroll up","Page Up"),
      ControlConfig.new("Registered","F5"),
      ControlConfig.new("Registered","Shift"),
      ControlConfig.new("Autorun","S"),
      ControlConfig.new("Quicksave","D"),
      ControlConfig.new("Fast-Forward","Alt"),
      ControlConfig.new("Special/Autosort","A"),
    ]
  end  
  
  def self.getKeyName(keyCode)
    ret  = CONTROLSLIST.index(keyCode) 
    return ret ? ret : (keyCode==0 ? "None" : "?")
  end 
end

 module Input
  class << self
    def buttonToKey(button)
      $PokemonSystem = PokemonSystem.new if !$PokemonSystem
      case button
        when Input::DOWN
          return $PokemonSystem.getGameControlCodes("Down")
        when Input::LEFT
          return $PokemonSystem.getGameControlCodes("Left")
        when Input::RIGHT
          return $PokemonSystem.getGameControlCodes("Right")
        when Input::UP
          return $PokemonSystem.getGameControlCodes("Up")
        when Input::A # Z, Shift
          return $PokemonSystem.getGameControlCodes("Run")
        when Input::B # X, ESC 
          return $PokemonSystem.getGameControlCodes("Cancel/Menu")
        when Input::C # C, ENTER, Space
          return $PokemonSystem.getGameControlCodes("Action")
        when Input::L # Page Up
          return $PokemonSystem.getGameControlCodes("Scroll up")
        when Input::R # Page Down
          return $PokemonSystem.getGameControlCodes("Scroll down")
 #       when Input::SHIFT
 #         return [0x10] # Shift
 #       when Input::CTRL
 #         return [0x11] # Ctrl
 #       when Input::ALT
 #         return [0x12] # Alt
        when Input::F5 # F5
          return $PokemonSystem.getGameControlCodes("Registered")
        when Input::Y # S
          return $PokemonSystem.getGameControlCodes("Autorun")   
        when Input::Z # D
          return $PokemonSystem.getGameControlCodes("Quicksave")             
        when Input::ALT # Alt
          return $PokemonSystem.getGameControlCodes("Fast-Forward")     
        when Input::X # A
          return $PokemonSystem.getGameControlCodes("Special/Autosort")        
 #       when Input::F6
 #         return [0x75] # F6
 #       when Input::F7
 #         return [0x76] # F7
 #       when Input::F8
 #         return [0x77] # F8
 #       when Input::F9
 #         return [0x78] # F9
        else
          return buttonToKeyOldFL(button)
      end
    end
  end
end

