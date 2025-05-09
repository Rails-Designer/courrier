namespace :tmp do
  task :courrier do
    rm_rf Dir["#{Courrier.configuration.preview.destination}/[^.]*"], verbose: false
  end

  task clear: :courrier
end

namespace :courrier do
  desc "Clear preview email files from `#{Courrier.configuration.preview.destination}`"

  task clear: "tmp:courrier"
end
