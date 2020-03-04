require 'csv'

module FileIO

  def create(file_path, all, class_name)
    CSV.foreach(file_path, headers: true, header_converters: :symbol) do |row|
      params = row.to_hash
      all << class_name.new(params)
    end
  end

end
