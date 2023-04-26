package target

import (
	"context"

	"github.com/iptecharch/schema-server/config"
	schemapb "github.com/iptecharch/schema-server/protos/schema_server"
	log "github.com/sirupsen/logrus"
)

type noopTarget struct {
	name string
}

func newNoopTarget(ctx context.Context, name string) (*noopTarget, error) {
	nt := &noopTarget{
		name: name,
	}
	return nt, nil
}

func (t *noopTarget) Get(ctx context.Context, req *schemapb.GetDataRequest) (*schemapb.GetDataResponse, error) {
	result := &schemapb.GetDataResponse{
		Notification: []*schemapb.Notification{},
	}
	return result, nil
}

func (t *noopTarget) Set(ctx context.Context, req *schemapb.SetDataRequest) (*schemapb.SetDataResponse, error) {
	result := &schemapb.SetDataResponse{
		Response: []*schemapb.UpdateResult{},
	}
	return result, nil
}

func (t *noopTarget) Subscribe() {
	return
}

func (t *noopTarget) Sync(ctx context.Context, _ *config.Sync, syncCh chan *SyncUpdate) {
	log.Infof("starting target %s sync", t.name)
	return
}

func (t *noopTarget) Close() {
	return
}
