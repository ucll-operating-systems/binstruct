require 'binstruct'


describe :BinStruct, :define_binstruct do
  context 'struct[u8]' do
    before :each do
      @description = BinStruct.define_binstruct do
        field :foo, u8
      end
    end

    it 'returns size 1' do
      expect(@description.size).to eql(1)
    end

    it 'returns offset 0 for :foo' do
      expect(@description.offset :foo).to eql(0)
    end

    context 'bytes [1]' do
      before :each do
        @bytes = [1]
        @struct = @description.create(@bytes)
      end

      it ':foo equals 1' do
        expect(@struct.foo).to eql(1)
      end
    end
  end

  context 'struct[u8 u8]' do
    before :each do
      @description = BinStruct.define_binstruct do
        field :foo, u8
        field :bar, u8
      end
    end

    it 'returns size 2' do
      expect(@description.size).to eql(2)
    end

    it 'returns offset 0 for :foo' do
      expect(@description.offset :foo).to eql(0)
    end

    it 'returns offset 1 for :bar' do
      expect(@description.offset :bar).to eql(1)
    end
  end

  context 'struct[u16 u8]' do
    before :each do
      @description = BinStruct.define_binstruct do
        field :foo, u16
        field :bar, u8
      end
    end

    it 'returns size 3' do
      expect(@description.size).to eql(3)
    end

    it 'returns offset 0 for :foo' do
      expect(@description.offset :foo).to eql(0)
    end

    it 'returns offset 2 for :bar' do
      expect(@description.offset :bar).to eql(2)
    end

    context 'bytes [1, 2, 3]' do
      before :each do
        @bytes = [1, 2, 3]
        @struct = @description.create(@bytes)
      end

      it ':foo equals 513' do
        expect(@struct.foo).to eql(513)
      end

      it ':bar equals 3' do
        expect(@struct.bar).to eql(3)
      end

      it 'setting :bar to 4' do
        @struct.bar = 4
        expect(@bytes).to eql([1,2,4])
      end
    end
  end

  context 'struct[u16 u8 u32 u16]' do
    before :each do
      @description = BinStruct.define_binstruct do
        field :foo, u16
        field :bar, u8
        field :baz, u32
        field :qux, u16
      end
    end

    it 'returns size 9' do
      expect(@description.size).to eql(9)
    end

    it 'returns offset 0 for :foo' do
      expect(@description.offset :foo).to eql(0)
    end

    it 'returns offset 2 for :bar' do
      expect(@description.offset :bar).to eql(2)
    end

    it 'returns offset 3 for :baz' do
      expect(@description.offset :baz).to eql(3)
    end

    it 'returns offset 7 for :qux' do
      expect(@description.offset :qux).to eql(7)
    end

    context 'bytes [1, 2, 3, 4, 5, 6, 7, 8, 9]' do
      before :each do
        @bytes = [1, 2, 3, 4, 5, 6, 7, 8, 9]
        @struct = @description.create(@bytes)
      end

      it ':foo has the correct value' do
        expect(@struct.foo).to eql(2 * 256 + 1)
      end

      it ':bar has the correct value' do
        expect(@struct.bar).to eql(3)
      end

      it ':baz has the correct value' do
        expect(@struct.baz).to eql(4 + 5 * 256 + 6 * 256**2 + 7 * 256**3)
      end

      it ':qux has the correct value' do
        expect(@struct.qux).to eql(8 + 9 * 256)
      end

      it 'setting :bar' do
        @struct.bar = 20
        expect(@bytes).to eql([1,2,20,4,5,6,7,8,9])
      end

      it 'setting :qux' do
        @struct.qux = 20
        expect(@bytes).to eql([1,2,3,4,5,6,7,20,0])
      end
    end
  end
end