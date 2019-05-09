class LeslieEnding
  @@endings = [
    "I love you.",
    "you are doing great.",
    "the world needs you.",
    "you butter my biscuit.",
    "you are smart as a whip.",
    "you are the sunshine of my life",
    "you are such a treat",
    "you are an angel",
    "you are a bright light in this dark world",
    "I am so lucky to know you",
    "you have great taste",
    "I would name my first-born after you",
    "you are going to do big things"
  ]

  def self.ending
    @@endings.sample
  end
end
