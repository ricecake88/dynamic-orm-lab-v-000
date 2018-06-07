require_relative "../config/environment.rb"
require 'active_support/inflector'
require 'pry'

class InteractiveRecord
  
  def initialize(attributes={})
    attributes.each {|key, value| self.send("#{key}=", value)}
  end
  
  def self.table_name
    self.to_s.downcase.pluralize
  end
  
  def self.column_names
    sql = "PRAGMA table_info(#{self.table_name})"
    table_info_hash = DB[:conn].execute(sql)
    column_names = []
    
    table_info_hash.each do |column|
      column_names << column["name"]
    end
    
    column_names.compact
  end
  
  def table_name_for_insert
    self.class.table_name
  end
  
  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end
  
  def values_for_insert
    values = []
    self.class.column_names.each do |col|
      values << "'#{send(col)}'" unless self.send(col).nil?
    end
    
    values.join(", ")
  end
  
  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES(#{values_for_insert})"
    
    DB[:conn].execute(sql)
    self.id = DB[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end
  
  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = '#{name}'"
    
    DB[:conn].execute(sql)
  end
  
  def self.find_by(attribute)
    sql = "SELECT * FROM #{self.table_name} WHERE #{attribute.keys.first.to_s} = '#{attribute.values.first.to_s}'"
    
    DB[:conn].execute(sql)
  end
end