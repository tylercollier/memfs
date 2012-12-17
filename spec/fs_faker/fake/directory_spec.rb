require 'spec_helper'

module FsFaker
  module Fake
    describe Directory do
      let(:fs) { FsFake::FileSystem.instance }
      let(:directory) { Directory.new('/test') }

      describe '.new' do
        it "sets . in the entries list" do
          directory.entries.should include('.' => directory)
        end

        it "sets .. in the entries list" do
          directory.entries.should have_key('..')
        end
      end

      describe '#add_entry' do
        let(:entry) { Directory.new('new_entry') }

        it "adds the entry to the entries list" do
          directory.add_entry entry
          directory.entries.should include('new_entry' => entry)
        end

        it "sets the parent of the added entry" do
          directory.add_entry entry
          entry.parent.should be(directory)
        end
      end

      describe '#entry_names' do
        it "returns the list of the names of the entries in the directory" do
          3.times do |n|
            directory.add_entry Directory.new("dir#{n}")
          end

          directory.entry_names.should == %w[. .. dir0 dir1 dir2]
        end
      end

      describe '#find' do
        let(:sub_directory) { Directory.new('sub_dir') }
        let(:file) { File.new('file') }

        before :each do
          sub_directory.add_entry file
          directory.add_entry sub_directory
        end

        it "returns the named entry if it is one of the entries" do
          directory.find('sub_dir').should be(sub_directory)
        end

        it "calls find on the next directory in the search chain" do
          directory.find('sub_dir/file').should be(file)
        end

        it "should remove any leading / in the path" do
          directory.find('/sub_dir/file').should be(file)
        end
      end

      describe '#parent=' do
        let(:parent) { Directory.new('parent') }

        it "sets the .. entry in entries list" do
          directory.parent = parent
          directory.entries.should include('..' => parent)
        end

        it "sets the parent directory" do
          directory.parent = parent
          directory.parent.should be(parent)
        end
      end
    end
  end
end
