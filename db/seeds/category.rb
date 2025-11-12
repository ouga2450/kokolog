puts "→ Seeding categories..."

categories = [
  { name: "運動", icon: "🏃‍♂️", description: "体を動かす" },
  { name: "勉強", icon: "📚", description: "学びを続ける" },
  { name: "生活", icon: "🏠", description: "暮らしを整える" },
  { name: "健康", icon: "🧘", description: "心身をケアする" },
  { name: "食事", icon: "🍎", description: "食生活を整える" },
  { name: "睡眠", icon: "🛏️", description: "睡眠を改善する" },
  { name: "仕事", icon: "💼", description: "仕事に集中する" },
  { name: "趣味", icon: "🎨", description: "好きなことを楽しむ" },
  { name: "日常", icon: "🌱", description: "毎日を整える" }
]

categories.each do |attrs|
  Category.find_or_create_by!(name: attrs[:name]) do |category|
    category.icon = attrs[:icon]
    category.description = attrs[:description]
  end
end

puts "✅ Category seeded: #{Category.count}"
