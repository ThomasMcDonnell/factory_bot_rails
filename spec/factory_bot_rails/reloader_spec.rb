# frozen_string_literal: true

describe FactoryBotRails::Reloader do
  describe "#run" do
    before do
      @original_definition_file_paths = FactoryBot.definition_file_paths
    end

    after do
      FactoryBot.definition_file_paths = @original_definition_file_paths
    end

    context "when a definition file paths exist" do
      it "registers a reloader" do
        reloader_class = reloader_class_double

        run_reloader(
          ["spec/fixtures/factories", "not_exist_directory"],
          reloader_class,
        )

        expect(reloader_class).to have_received(:new)
      end
    end

    context "when a file exists but not a directory" do
      it "registers a reloader" do
        reloader_class = reloader_class_double

        run_reloader(
          ["spec/fake_app", "not_exist_directory"],
          reloader_class,
        )

        expect(reloader_class).to have_received(:new)
      end
    end

    context "when a definition file paths NOT exist" do
      it "does NOT register a reloader" do
        reloader_class = reloader_class_double

        run_reloader(["not_exist_directory"], reloader_class)

        expect(reloader_class).not_to have_received(:new)
      end
    end

    def run_reloader(definition_file_paths, reloader_class)
      FactoryBot.definition_file_paths = definition_file_paths

      app = app_double(reloader_class)
      FactoryBotRails::Reloader.new(app).run
    end

    def reloader_class_double
      class_double(
        Rails.application.config.file_watcher,
        new: double(:reloader, execute: nil),
      )
    end

    def app_double(reloader_class)
      instance_double(
        Rails.application.class,
        config: app_config_double(reloader_class),
        reloader: Rails.application.reloader,
        reloaders: [],
      )
    end

    def app_config_double(reloader_class)
      instance_double(
        Rails.application.config.class,
        file_watcher: reloader_class,
      )
    end
  end
end
