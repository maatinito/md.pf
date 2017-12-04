module DossierHelper
  def button_or_label_class(dossier)
    if dossier.accepte?
      'accepted'
    elsif dossier.without_continuation?
      'without-continuation'
    elsif dossier.refused?
      'refused'
    end
  end

  def highlight_if_unseen_class(seen_at, updated_at)
    if seen_at&.<(updated_at)
      "highlighted"
    end
  end
end
