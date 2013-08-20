
# Provide a nice truncated output for summaries
class String
  def truncate(lim, ellipsis='...', pad=' ')
    ellipsis = '' if self.length <= lim
    return ellipsis[ellipsis.length - lim..-1] if lim <= ellipsis.length
    return self[0..(lim - ellipsis.length)-1] + ellipsis + (pad * [lim - self.length, 0].max)
  end
end


