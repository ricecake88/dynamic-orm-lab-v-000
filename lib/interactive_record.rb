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
  end
  
end