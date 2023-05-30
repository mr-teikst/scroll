package config_test

import (
	"encoding/json"
	"fmt"
	"os"
	"testing"
	"time"

	"github.com/stretchr/testify/assert"

	"scroll-tech/bridge/config"
)

func TestConfig(t *testing.T) {
	cfg, err := config.NewConfig("../config.json")
	assert.True(t, assert.NoError(t, err), "failed to load config")

	assert.Equal(t, 1, len(cfg.L1Config.RelayerConfig.MessageSenderPrivateKeys))
	assert.Equal(t, 1, len(cfg.L2Config.RelayerConfig.MessageSenderPrivateKeys))
	assert.Equal(t, 1, len(cfg.L2Config.RelayerConfig.RollupSenderPrivateKeys))

	data, err := json.Marshal(cfg)
	assert.NoError(t, err)

	tmpJosn := fmt.Sprintf("/tmp/%d_bridge_config.json", time.Now().Nanosecond())
	defer func() { _ = os.Remove(tmpJosn) }()

	assert.NoError(t, os.WriteFile(tmpJosn, data, 0644))

	cfg2, err := config.NewConfig(tmpJosn)
	assert.NoError(t, err)

	assert.Equal(t, cfg.L1Config, cfg2.L1Config)
	assert.Equal(t, cfg.L2Config, cfg2.L2Config)
	assert.Equal(t, cfg.DBConfig, cfg2.DBConfig)
}