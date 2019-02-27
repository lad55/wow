dPlayers = {"Asdf", "Qwer", "Zxcv"}
healers = {
  {"Musaxinho", true},
  {"Luidz", true},
  {"Jackroberto", true},
  {"Pedrilho", true},
  {"Nittrilho", true},
}
me = "Luidz"
i = 0

for k, v in pairs(healers) do
  if v[2] then
      print("DISPELLA O {rt" .. (i%3) + 1 .. "} " .. dPlayers[(i%3 + 1)])
  end
  i = i + 1
end