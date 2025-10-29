puts "→ Seeding feelings..."

feelings = [
  { name: "リラックス" },
  { name: "嬉しい" },
  { name: "イライラ" },
  { name: "悲しい" },
  { name: "疲れた" }
]

feelings.each do |attrs|
  Feeling.find_or_create_by!(name: attrs[:name])
end

puts "✅ Feelings seeded: #{Feeling.count}"
