puts "→ Seeding moods..."

presets = [
  { score: 1, label: "very_bad",  color: "bg-blue-300" },
  { score: 2, label: "bad",       color: "bg-sky-300" },
  { score: 3, label: "neutral",   color: "bg-yellow-300" },
  { score: 4, label: "good",      color: "bg-orange-300" },
  { score: 5, label: "very_good", color: "bg-pink-300" }
]

presets.each do |attrs|
  Mood.find_or_create_by!(score: attrs[:score]) do |mood|
    mood.label = attrs[:label]
    mood.color = attrs[:color]
  end
end

puts "✅ Moods seeded: #{Mood.count}"
