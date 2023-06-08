package common_rules

import future.keywords.in
import input

allowed := {"chronicle", "anonymous"}

allowed_users {
  input.type in allowed
}
