require File.join(File.dirname(__FILE__), *%w[.. .. .. spec_helper])

def roster_xml
  <<-XML
  <iq to='juliet@example.com/balcony' type='result' id='roster_1'>
    <query xmlns='jabber:iq:roster'>
      <item jid='romeo@example.net'
            name='Romeo'
            subscription='both'>
        <group>Friends</group>
      </item>
      <item jid='mercutio@example.org'
            name='Mercutio'
            subscription='from'>
        <group>Friends</group>
      </item>
      <item jid='benvolio@example.org'
            name='Benvolio'
            subscription='both'>
        <group>Friends</group>
      </item>
    </query>
  </iq>
  XML
end

describe 'Blather::Stanza::Iq::Roster' do
  it 'registers itself' do
    XMPPNode.class_from_registration(:query, 'jabber:iq:roster').must_equal Stanza::Iq::Roster
  end

  it 'ensures newly inherited items are RosterItem objects' do
    n = XML::Document.string roster_xml
    r = Stanza::Iq::Roster.new.inherit n.root
    r.items.map { |i| i.class }.uniq.must_equal [Stanza::Iq::Roster::RosterItem]
  end
end

describe 'Blather::Stanza::Iq::Roster::RosterItem' do
  it 'can be initialized with just a JID' do
    i = Stanza::Iq::Roster::RosterItem.new 'n@d/r'
    i.jid.must_equal JID.new('n@d/r')
  end

  it 'can be initialized with a name' do
    i = Stanza::Iq::Roster::RosterItem.new nil, 'foobar'
    i.name.must_equal 'foobar'
  end

  it 'can be initialized with a subscription' do
    i = Stanza::Iq::Roster::RosterItem.new nil, nil, :both
    i.subscription.must_equal :both
  end

  it 'can be initialized with ask (subscription sub-type)' do
    i = Stanza::Iq::Roster::RosterItem.new nil, nil, nil, :subscribe
    i.ask.must_equal :subscribe
  end

  it 'inherits a node when initialized with one' do
    n = XMPPNode.new 'item'
    n['jid'] = 'n@d/r'
    n['subscription'] = 'both'

    i = Stanza::Iq::Roster::RosterItem.new n
    i.jid.must_equal JID.new('n@d/r')
    i.subscription.must_equal :both
  end

  it 'has a #groups helper that gives an array of groups' do
    n = XML::Document.string "<item jid='romeo@example.net' subscription='both'><group>foo</group><group>bar</group><group>baz</group></item>"
    i = Stanza::Iq::Roster::RosterItem.new n.root
    i.must_respond_to :groups
    i.groups.sort.must_equal %w[bar baz foo]
  end

  it 'has a helper to set the groups' do
    n = XML::Document.string "<item jid='romeo@example.net' subscription='both'><group>foo</group><group>bar</group><group>baz</group></item>"
    i = Stanza::Iq::Roster::RosterItem.new n.root
    i.must_respond_to :groups=
    i.groups.sort.must_equal %w[bar baz foo]
    i.groups = %w[a b c]
    i.groups.sort.must_equal %w[a b c]
  end

  it 'can be easily converted into a proper stanza' do
    xml = "<item jid='romeo@example.net' subscription='both'><group>foo</group><group>bar</group><group>baz</group></item>"
    n = XML::Document.string xml
    i = Stanza::Iq::Roster::RosterItem.new n.root
    i.must_respond_to :to_stanza
    s = i.to_stanza
    s.must_be_kind_of Stanza::Iq::Roster
    s.items.first.jid.must_equal JID.new('romeo@example.net')
    s.items.first.groups.sort.must_equal %w[bar baz foo]
  end

  it 'has an "attr_accessor" for jid' do
    i = Stanza::Iq::Roster::RosterItem.new
    i.must_respond_to :jid
    i.jid.must_be_nil
    i.must_respond_to :jid=
    i.jid = 'n@d/r'
    i.jid.must_equal JID.new('n@d/r')
  end

  it 'has an "attr_accessor" for name' do
    i = Stanza::Iq::Roster::RosterItem.new
    i.must_respond_to :name
    i.name.must_be_nil
    i.must_respond_to :name=
    i.name = 'name'
    i.name.must_equal 'name'
  end

  it 'has an "attr_accessor" for subscription' do
    i = Stanza::Iq::Roster::RosterItem.new
    i.must_respond_to :subscription
    i.subscription.must_be_nil
    i.must_respond_to :subscription=
    i.subscription = :both
    i.subscription.must_equal :both
  end

  it 'has an "attr_accessor" for ask' do
    i = Stanza::Iq::Roster::RosterItem.new
    i.must_respond_to :ask
    i.ask.must_be_nil
    i.must_respond_to :ask=
    i.ask = :subscribe
    i.ask.must_equal :subscribe
  end
end
