package graph

import (
	utility "gateway/service"
)

type Resolver struct {
	UserClient utility.UserServiceClient
	PostClient utility.PostServiceClient
	// ConnectionsClient utility.ConnectionsServiceClient
}
