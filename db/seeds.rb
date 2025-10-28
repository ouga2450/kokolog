puts "🌱 Start seeding..."

Dir[File.join(Rails.root, 'db', 'seeds', '*.rb')].sort.each do |file|
  puts "→ Loading #{File.basename(file)}"
  load(file)
end

puts "✅ All seeds completed!"
