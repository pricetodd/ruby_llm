# RubyLLM

A delightful Ruby interface to the latest large language models. Stop wrestling with multiple APIs and inconsistent interfaces. RubyLLM gives you a clean, unified way to work with models from OpenAI, Anthropic, and more.

[![Gem Version](https://badge.fury.io/rb/ruby_llm.svg)](https://badge.fury.io/rb/ruby_llm)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-standard-brightgreen.svg)](https://github.com/testdouble/standard)

## Installation

Add it to your Gemfile:

```ruby
gem 'ruby_llm'
```

Or install it yourself:

```bash
gem install ruby_llm
```

## Quick Start

RubyLLM makes it dead simple to start chatting with AI models:

```ruby
require 'ruby_llm'

# Configure your API keys
RubyLLM.configure do |config|
  config.openai_api_key = ENV['OPENAI_API_KEY']
  config.anthropic_api_key = ENV['ANTHROPIC_API_KEY']
end

# Start a conversation
chat = RubyLLM.chat
chat.ask "What's the best way to learn Ruby?"
```

## Available Models

RubyLLM gives you access to the latest models from multiple providers. Check what's available:

```ruby
# List all available models
RubyLLM.models.all

# Get models by type
chat_models = RubyLLM.models.chat_models
embedding_models = RubyLLM.models.embedding_models
audio_models = RubyLLM.models.audio_models
image_models = RubyLLM.models.image_models
```

## Having a Conversation

Conversations are simple and natural, with automatic token counting built right in:

```ruby
chat = RubyLLM.chat model: 'claude-3-5-sonnet-20241022'

# Single messages with token tracking
response = chat.ask "What's your favorite Ruby feature?"
puts "Response used #{response.input_tokens} input tokens and #{response.output_tokens} output tokens"

# Multi-turn conversations just work
chat.ask "Can you elaborate on that?"
chat.ask "How does that compare to Python?"

# Stream responses as they come
chat.ask "Tell me a story about a Ruby programmer" do |chunk|
  print chunk.content
end

# Get token usage for the whole conversation from the last message
last_message = chat.messages.last
puts "Conversation used #{last_message.input_tokens} input tokens and #{last_message.output_tokens} output tokens"
```

## Choosing the Right Model

RubyLLM gives you easy access to model capabilities:

```ruby
model = RubyLLM.models.find 'claude-3-5-sonnet-20241022'

model.context_window      # => 200000
model.max_tokens          # => 8192
model.supports_vision     # => true
model.supports_json_mode  # => true
```

## Coming Soon

- Rails integration for seamless database and Active Record support
- Function calling / tool use capabilities
- Automatic retries and error handling
- Much more!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/crmne/ruby_llm.

## License

Released under the MIT License. See LICENSE.txt for details.