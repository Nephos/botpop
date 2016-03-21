class Character

  attr_accessor :carac, :skills, :hp, :classes, :bab
  def initialize(str, dex, con, int, wiz, cha, opt={})
    @carac = {str: str, dex: dex, con: con, int: int, wiz: wiz, cha: cha}
    @skills = {}
    @hp = opt[:hp] || nil
    @classes = opt[:classes] || {}
    @bab = opt[:bab] || [0]
  end

end
