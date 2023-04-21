package server

import (
	"context"

	schemapb "github.com/iptecharch/schema-server/protos/schema_server"
	log "github.com/sirupsen/logrus"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/status"
)

// data

func (s *Server) GetData(ctx context.Context, req *schemapb.GetDataRequest) (*schemapb.GetDataResponse, error) {
	log.Infof("received GetDataRequest: %v", req)
	name := req.GetName()
	if name == "" {
		return nil, status.Errorf(codes.InvalidArgument, "missing datastore name")
	}
	switch req.GetDataType() {
	case schemapb.DataType_STATE:
		if req.GetDatastore().GetType() == schemapb.Type_CANDIDATE {
			return nil, status.Errorf(codes.InvalidArgument, "a candidate datastore does not store state data")
		}
	}
	s.md.RLock()
	defer s.md.RUnlock()
	ds, ok := s.datastores[name]
	if !ok {
		return nil, status.Errorf(codes.InvalidArgument, "unknown datastore %s", name)
	}
	return ds.Get(ctx, req)
}

func (s *Server) SetData(ctx context.Context, req *schemapb.SetDataRequest) (*schemapb.SetDataResponse, error) {
	log.Infof("received SetDataRequest: %v", req)
	name := req.GetName()
	if name == "" {
		return nil, status.Errorf(codes.InvalidArgument, "missing datastore name")
	}
	s.md.RLock()
	defer s.md.RUnlock()
	ds, ok := s.datastores[name]
	if !ok {
		return nil, status.Errorf(codes.InvalidArgument, "unknown datastore %s", name)
	}
	return ds.Set(ctx, req)
}

func (s *Server) Diff(ctx context.Context, req *schemapb.DiffRequest) (*schemapb.DiffResponse, error) {
	log.Infof("received DiffRequest: %v", req)
	name := req.GetName()
	if name == "" {
		return nil, status.Errorf(codes.InvalidArgument, "missing datastore name")
	}
	s.md.RLock()
	defer s.md.RUnlock()
	ds, ok := s.datastores[name]
	if !ok {
		return nil, status.Errorf(codes.InvalidArgument, "unknown datastore %s", name)
	}
	return ds.Diff(ctx, req)
}

func (s *Server) Subscribe(req *schemapb.SubscribeRequest, stream schemapb.DataServer_SubscribeServer) error {
	log.Infof("received SubscribeRequest: %v", req)
	name := req.GetName()
	if name == "" {
		return status.Errorf(codes.InvalidArgument, "missing datastore name")
	}
	s.md.RLock()
	ds, ok := s.datastores[name]
	s.md.RUnlock()
	if !ok {
		return status.Errorf(codes.InvalidArgument, "unknown datastore %s", name)
	}
	ds.Subscribe(req, stream)
	return status.Errorf(codes.Unimplemented, "method Subscribe not implemented")
}
