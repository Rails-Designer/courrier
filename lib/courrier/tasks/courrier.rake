namespace :tmp do
  task :courrier do
    rm_rf Dir["#{Courrier.configuration.inbox.destination}/[^.]*"], verbose: false
  end

  task clear: :courrier
end

namespace :courrier do
  desc "Clear email files from `#{Courrier.configuration.inbox.destination}`"

  task clear: "tmp:courrier"
end
