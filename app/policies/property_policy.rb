class PropertyPolicy < ApplicationPolicy
  def download_to_csv?
    return true
  end
  class Scope < Scope
    def resolve
      scope
    end
  end
end
