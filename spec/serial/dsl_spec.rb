describe "Serial DSL" do
  def serialize(&block)
    Serial::Serializer.new(&block).call(nil, nil)
  end

  describe "HashBuilder" do
    describe "#attribute" do
      it "serializes simple attributes" do
        data = serialize { |h| h.attribute(:hello, "World") }

        expect(data).to eq({ "hello" => "World" })
      end

      it "serializes nested attributes" do
        data = serialize do |h|
          h.attribute(:hi) { |h| h.attribute(:hello, "World") }
        end

        expect(data).to eq({ "hi" => { "hello" => "World" } })
      end

      it "forwards value when serializing nested attributes" do
        data = serialize do |h|
          h.attribute(:hi, "World") { |h, x| h.attribute(:hello, x) }
        end

        expect(data).to eq({ "hi" => { "hello" => "World" } })
      end

      it "explodes if the attribute already exists" do
        serializer = Serial::Serializer.new do |h|
          h.attribute(:hi, "a")
          h.attribute(:hi, "b")
        end

        expect { serializer.call(nil, nil) }.to raise_error(Serial::DuplicateKeyError, "'hi' is already defined")
      end
    end

    describe "#map" do
      it "serializes a list of values" do
        data = serialize do |h|
          h.map(:numbers, ["a", "b", "c"]) do |h, x|
            h.attribute(:x, x)
            h.attribute(:X, x.upcase)
          end
        end

        expect(data).to eq({
          "numbers" => [
            { "x" => "a", "X" => "A" },
            { "x" => "b", "X" => "B" },
            { "x" => "c", "X" => "C" },
          ]
        })
      end

      it "explodes if the attribute already exists" do
        serializer = Serial::Serializer.new do |h|
          h.attribute(:hi, "a")
          h.map(:hi, [1]) do |h, id|
            h.attribute(:id, id)
          end
        end

        expect { serializer.call(nil, nil) }.to raise_error(Serial::DuplicateKeyError, "'hi' is already defined")
      end
    end

    describe "#collection" do
      it "serializes a collection" do
        data = serialize do |h|
          h.collection(:numbers) do |l|
          end
        end

        expect(data).to eq({ "numbers" => [] })
      end

      it "explodes if the attribute already exists" do
        serializer = Serial::Serializer.new do |h|
          h.attribute(:hi, "a")
          h.collection(:hi) do |l|
            l.element do |h|
              h.attribute(:id, 1)
            end
          end
        end

        expect { serializer.call(nil, nil) }.to raise_error(Serial::DuplicateKeyError, "'hi' is already defined")
      end
    end

    describe "!-methods" do
      describe "#attribute!" do
        it "does not explode if the attribute already exists" do
          serializer = Serial::Serializer.new do |h|
            h.attribute(:hi, "a")
            h.attribute!(:hi, "b")
          end

          expect(serializer.call(nil, nil)).to eq({ "hi" => "b" })
        end
      end

      describe "#map!" do
        it "does not explode if the attribute already exists" do
          serializer = Serial::Serializer.new do |h|
            h.attribute(:hi, "a")
            h.map!(:hi, [1]) do |h, id|
              h.attribute(:id, id)
            end
          end

          expect(serializer.call(nil, nil)).to eq({ "hi" => [{ "id" => 1 }] })
        end
      end

      describe "#collection!" do
        it "does not explode if the attribute already exists" do
          serializer = Serial::Serializer.new do |h|
            h.attribute(:hi, "a")
            h.collection!(:hi) do |l|
              l.element do |h|
                h.attribute(:id, 1)
              end
            end
          end

          expect(serializer.call(nil, nil)).to eq({ "hi" => [{ "id" => 1 }] })
        end
      end
    end
  end

  describe "ArrayBuilder" do
    def collection(&block)
      serialize { |h| h.collection(:collection, &block) }
    end

    describe "#element" do
      it "serializes a hash in a collection" do
        data = collection do |l|
          l.element { |h| h.attribute(:hello, "World") }
          l.element { |h| h.attribute(:hi, "There") }
        end

        expect(data).to eq({
          "collection" => [
            { "hello" => "World" },
            { "hi" => "There" }
          ]
        })
      end
    end

    describe "#collection" do
      it "serializes a collection inside of a collection" do
        data = collection do |l|
          l.collection do |l|
            l.element { |h| h.attribute(:hello, "World") }
            l.element { |h| h.attribute(:hi, "There") }
          end

          l.collection do |l|
            l.element { |h| h.attribute(:piff, "Puff") }
          end
        end

        expect(data).to eq({
          "collection" => [
            [{ "hello" => "World" }, { "hi" => "There" }],
            [{ "piff" => "Puff" }]
          ]
        })
      end
    end
  end
end
