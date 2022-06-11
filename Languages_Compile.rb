def aaapbCompileTextLanguages
  for i in 0...LANGUAGES.length
    if safeExists?(LANGUAGES[i][1]+".temp")
      aaapbCompileTextLanguages_One(LANGUAGES[i][1])
      File.delete(LANGUAGES[i][1]+".temp")
    end
  end
end

def aaapbCompileTextLanguages_One(sFile)
  outfile=File.open("./Data/"+sFile,"wb")
  begin
    intldat=pbGetText(sFile+".txt")
    Marshal.dump(intldat,outfile)
  rescue
    raise
  ensure
    outfile.close
  end
end
 
aaapbCompileTextLanguages

